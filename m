From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/3] ifb: make device count build-time configurable
Date: Tue, 12 Jan 2016 07:55:22 -0500
Message-ID: <5694F7BA.3040402@mojatatu.com>
References: <1452599804-27284-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Lubomir Rintel <lkundrak@v3.sk>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452599804-27284-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-01-12 06:56 AM, Lubomir Rintel wrote:
> The devices can be created at run-time for quite some time already and the
> load-time device creation collides with attempts to create the device of
> the same name:
>
>    # rmmod ifb
>    # ip link add ifb0 type ifb
>    RTNETLINK answers: File exists
>
> This is pretty much the same situation as was with the block loop devices
> which was solved by adding a build-time configuration that the
> distributions could use as they deem fit while keeping the default for
> compatibility.
>
> Let's do that here as well.
>
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

I guess module options are frowned upon. so:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
