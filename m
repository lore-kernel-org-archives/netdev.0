From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bonding: make device count build-time configurable
Date: Tue, 12 Jan 2016 15:45:50 -0500 (EST)
Message-ID: <20160112.154550.2297969991865269932.davem@davemloft.net>
References: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
	<8166.1452616452@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkundrak@v3.sk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: jay.vosburgh@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8166.1452616452@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Tue, 12 Jan 2016 08:34:12 -0800

> Lubomir Rintel <lkundrak@v3.sk> wrote:
> 
>>The devices can be created at run-time for quite some time already and the
>>load-time device creation collides with attempts to create the device of
>>the same name:
>>
>>  # rmmod bonding
>>  # ip link add bond0 type bond
>>  RTNETLINK answers: File exists
>>
>>This is pretty much the same situation as was with the block loop devices
>>which was solved by adding a build-time configuration that the
>>distributions could use as they deem fit while keeping the default for
>>compatibility.
> 
> 	I agree this is annoying, but I would expect distros to leave
> this set to 1 (for backwards compatibility with scripts that "modprobe
> bonding" then assume bond0 exists).  This leaves the problem in place
> for the vast majority of users.
> 
> 	Is there a reasonable way to resolve this that would actually
> fix things for regular distro kernel users?

Yeah I personally don't like this at all.

This behavior has 2 decades of precedence, it's therefore hard coded
into deep dark nooks and cranies of people's scripts.

Just be content with how things are, and document it better if need
be.
