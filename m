From: Gilles Quillard <gilles.quillard@bull.net>
Subject: support of IPv6 by NFS
Date: Tue, 01 Mar 2005 11:10:21 +0100
Message-ID: <42243F8D.5030302@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gerrit Huizenga <gh@us.ibm.com>, Tony Reix <Tony.Reix@bull.net>
To: netdev@oss.sgi.com, linux-ipv6@list.f00f.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm working on the support of IPv6 by NFS and the RPC on Linux.

As now preconized for the developing of new networking applications, I 
have developed a prototype implementation on which I have migrated all 
the NFS / RPC kernel stack and the user commands to use IPv6 addresses. 
The IPv4-mapping mechanism is used to assume the backward compatibility 
for IPv4 addresses which are still the most used.
This works but this needs that the kernel has been compiled with IPv6, 
which is not mandotary. A lot of people in the Linux community do not 
have experience with IPv6 yet and are not ready to use it. So making it 
mandatory for NFS, even in a pure IPv4 network, is not easy.
It seems that the most of the major distributions already provide 
default kernel built with IPv6, but the reference on kernel.org is still 
providing with the IPv6 support not set; and there are some 
unwillingness to make mandatory the compilation of the kernel with IPv6 
to support NFS.

The problem is not specific to NFS, any networking application written 
using IPv6 mechanisms for both IPv4 and IPv6 addresses (AF_INET6 socket 
opened, IPv4 addresses mapped) couldn't work without a kernel built with 
IPv6.

Are the final users really against the use of kernels built with IPv6 ?
What is preconized on Linux for the support of IPv6 ? The solution 
described above or the cohabitation of the two modes (struct sockaddr or 
sockaddr_storage used to contain either struct sockaddr_in or struct 
sockaddr_in6) with specific processing according to the family of the 
addresses ?

Regards,
Gilles
