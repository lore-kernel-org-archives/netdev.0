From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH 3/3] bonding: make device count build-time configurable
Date: Tue, 12 Jan 2016 08:34:12 -0800
Message-ID: <8166.1452616452@famine>
References: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lubomir Rintel <lkundrak@v3.sk> wrote:

>The devices can be created at run-time for quite some time already and the
>load-time device creation collides with attempts to create the device of
>the same name:
>
>  # rmmod bonding
>  # ip link add bond0 type bond
>  RTNETLINK answers: File exists
>
>This is pretty much the same situation as was with the block loop devices
>which was solved by adding a build-time configuration that the
>distributions could use as they deem fit while keeping the default for
>compatibility.

	I agree this is annoying, but I would expect distros to leave
this set to 1 (for backwards compatibility with scripts that "modprobe
bonding" then assume bond0 exists).  This leaves the problem in place
for the vast majority of users.

	Is there a reasonable way to resolve this that would actually
fix things for regular distro kernel users?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
