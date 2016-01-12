From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/3] dummy: make device count build-time configurable
Date: Tue, 12 Jan 2016 10:42:47 -0800
Message-ID: <20160112104247.1004c32c@xeon-e3>
References: <1452599853-27399-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452599853-27399-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Jan 2016 12:57:33 +0100
Lubomir Rintel <lkundrak@v3.sk> wrote:

> The devices can be created at run-time for quite some time already and the
> load-time device creation collides with attempts to create the device of
> the same name:
> 
>   # rmmod dummy
>   # ip link add dummy0 type dummy
>   RTNETLINK answers: File exists
> 
> This is pretty much the same situation as was with the block loop devices
> which was solved by adding a build-time configuration that the
> distributions could use as they deem fit while keeping the default for
> compatibility.
> 
> Let's do that here as well.
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

There is already a module parameter for this, so making it a compile
time option adds nothing.
