From: Patrick McHardy <kaber@trash.net>
Subject: Re: Last night Linus bk - netfilter busted?
Date: Fri, 11 Mar 2005 15:00:56 +0100
Message-ID: <4231A498.4020101@trash.net>
References: <200503110223.34461.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <200503110223.34461.dtor_core@ameritech.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Torokhov wrote:
> My box gets stuck while booting (actually starting ntpd) whith tonight
> pull from Linus. It looks like it is spinning in ipt_do_table when I do
> SysRq-P. No call trace though.

Please post your ruleset and .config. A backtrace would also be
useful.

> Anyone else seeing it? Any ideas?

Works fine here. You could try if reverting one of these two patches
helps (second one only if its a SMP box).

ChangeSet@1.2010, 2005-03-09 20:28:17-08:00, bdschuym@pandora.be
   [NETFILTER]: Reduce call chain length in netfilter (take 2)

ChangeSet@1.1982.114.20, 2005-03-03 23:15:48+01:00, ak@suse.de
   [NETFILTER]: Reduce netfilter memory use on MP systems

Regards
Patrick
