From: Jamal Hadi Salim <hadi@znyx.com>
Subject: iptables versioning feature causes ABI breakage
Date: 24 Mar 2005 07:11:40 -0500
Message-ID: <1111666300.1037.40.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>, netdev@oss.sgi.com
To: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        netfilter-devel@lists.netfilter.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Folks,

Could whoever that made the versioning changes in iptables please
contact me?
I am CCing netdev because netfilter-devel seems to bounce my emails.

I need to punish him/her/them by having them look at my
tc code to make sure that i didnt miss some trick they used 
(I just found out how the target name was being abused to carry
versions;->). In the future please please remember there are other
users of these goods other than iptables.

I am willing to say "works only with iptables >= 1.3.1"  and make
sure tc pukes on lower versions. It would be better if i could say
"ok, user space is 1.2.1 which doesnt have versioning support - heres
what i need to do"

Kernel/userspace mismatch otoh may be a problem even if i decice in user
space i am gonna stick with iptables that has the versioning feature.
How do i detect that a kernel which has iptables support also has
versioning feature?

cheers,
jamal
