From: paul.moore@hp.com
Subject: [RFC 0/7] Updated NetLabel patch
Date: Wed, 21 Jun 2006 15:42:35 -0400
Message-ID: <20060621194234.979661000@flek.zko.hp.com>
Cc: jmorris@redhat.com, sgrubb@redhat.com, sds@epoch.ncsc.mil
Return-path: <redhat-lspp-bounces@redhat.com>
To: redhat-lspp@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

This is an updated version of the NetLabel patch I sent out on May 25th.  It
contains a variety of fixes and incorporates comments from James Morris,
Stephen Smalley, and Steve Grubb.  An intermediate version of this patch set
has also been tested against Trusted Solaris and HP-UX CMW for CIPSO
interoperability.  I have tested this patch set on x86 and x86_64
architectures running both the targeted/enforcing and mls/permissive SELinux
policies.

Just like before I am sending this patch out in an effort to solicit feedback
from developers, any comments you can afford to send would be greatly
appreciated.  While the patch is still "unfinished" my current todo list is
much shorter, the major tasks still remaining are:

 * protect against setsockopt() calls
 * address the remaining "PM" comments

For those wishing to try the patch for themselves you will need to download
and install the NetLabel tools.  The tools are used to configure the NetLabel
subsystem, documentation (including a man page) is included in the tarball.
The NetLabel tools, as well as more information, can be found here:

 * http://free.linux.hp.com/~pmoore/projects/linux_cipso

Thanks.

--
paul moore
linux security @ hp
