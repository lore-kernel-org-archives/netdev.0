From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: e1000: driver reboot/kexec bug.
Date: 17 Feb 2005 12:53:05 -0700
Message-ID: <m1sm3v55ge.fsf@ebiederm.dsl.xmission.com>
References: <468F3FDA28AA87429AD807992E22D07E044A15C5@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <jgarzik@pobox.com>,
        "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>,
        <netdev@oss.sgi.com>, <fastboot@osdl.org>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E044A15C5@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Venkatesan, Ganesh" <ganesh.venkatesan@intel.com> writes:

> >Do you know enough about kexec to attempt to reproduce this problem
> >that way?
> 
> Not much. All I have is an old paper by Andy Pfiffer. Could you point me
> to more resources on this?

Short explanation:

The user space lives at:
http://www.xmission.com/~ebiederm/files/kexec/kexec-tools-1.101.tar.gz
Other bits and pieces can be found at:
http://www.xmission.com/~ebiederm/files/kexec/

The latest patches are in the -mm tree.

Usually it is as simple as:
/sbin/kexec -l /path/to/bzImage --append='your command line options'
Then drop to single user mode and do:
/sbin/kexec -e

My patches have not made into the initscripts yet so doing a clean system
shutdown has not been fully automated yet.  

i386 and x86-64 architectures should both work.

Not it is a matter of slowing digging into the hardware support code and
getting out the bugs that are revealed.

Eric
