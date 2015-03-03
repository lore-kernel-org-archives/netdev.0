From: Michel Machado <michel@digirati.com.br>
Subject: Linux XIA - merge proposal
Date: Tue, 03 Mar 2015 12:29:18 -0500
Message-ID: <54F5EF6E.9090303@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

    We have been developing Linux XIA, a new network stack that 
emphasizes evolvability and interoperability, for a couple of years, and 
it has now reached a degree of maturity that allows others to experiment 
with it.  In addition to the kernel implementation, we have a userland 
tool to set up the stack, a Wireshark fork with extensions for XIA 
packets, an implemented solution to interoperate with IPv4 networks, 
forwarding performance evaluation of our code, support for Linux 
containers, and an exemplifying demo; all documented on our wiki [1]. 
Outlining the full benefits of XIA goes beyond the scope of this e-mail, 
but we present an in-depth discussion on our wiki and in our 
peer-reviewed academic publications referenced there.

    Linux XIA is not yet mature enough for production, but we do think 
that broader exposure will help us to move forward faster, and get more 
in tune with the interested community. Thus, we are writing to ask to 
merge our work into the Linux kernel.

    We are aware of all of the effort required to review a large chunk 
of code, so to lower this burden, we propose to merge our new network 
stack via staging. This would give time for the community at large to 
get acquainted with XIA's concepts, and review the code. Of course, we 
will address feedback as it comes in. We're aware that the current Linux 
staging process [2] is geared toward drivers and filesystems, but not 
network stacks. We're fine with clearly marking Linux XIA as being under 
staging as well as helping to define this review process for network stacks.

    Linux XIA is highly confined in its folder net/xia. There are a few 
headers in folder include/net, but all the names of these headers are of 
the form xia_*.h. Patches outside these files are minimal. This high 
isolation is a guarantee that Linux XIA can be dropped out of the kernel 
with little work if needed.

    Finally, there are several other research groups around the world 
working on other future Internet architectures.  We hope that the 
process of merging Linux XIA will provide a template for these other 
groups to merge their network stacks into Linux in the future.

    Thank you very much for your time,


[1] https://github.com/AltraMayor/XIA-for-Linux/wiki
[2] http://www.kroah.com/log/linux/linux-staging-update.html

-- 
[ ]'s
Michel Machado
on behalf of the Linux XIA team at Boston University
