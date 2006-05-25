From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC 0/4] NetLabel
Date: Thu, 25 May 2006 13:58:46 -0700
Message-ID: <20060525135846.44791440@localhost.localdomain>
References: <44760E29.4070407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <44760E29.4070407@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006 16:06:01 -0400
Paul Moore <paul.moore@hp.com> wrote:

> This patch introduces a new kernel feature designed to support labeled
> networking protocols such as RIPSO and CIPSO.  These protocols are required to
> interoperate with existing "trusted" operating systems such as Trusted Solaris.
> I am posting the patch now not because I feel it is ready for inclusion into
> any of the main kernel trees but because it is usable and I would like to
> solicit comments from the community sooner rather than later.
> 
> I know there has been at least one previous effort to get CIPSO support into
> the kernel and that was rejected.  I have tried to take the feedback from that
> patch into consideration with this patch and create a new mechanism which
> treads as lightly as possible on the core networking stack.  I have also
> worked to make the new patch LSM agnostic so that this code can be shared
> amongst multiple LSMs; while I am only providing a patch for SELinux at this
> point I do understand that there is at least one other LSM that is interested
> in making use of this new mechanism.
> 
> I understand that there will probably need to be a lengthy review period due
> to the size and complexity of this patch.  I also understand that my relative
> inexperience with submitting patches to the Linux kernel will not do much to
> help my cause but I appreciate your patience and any comments you may have.
> 
> There is a more information as well as a basic userspace tool for configuration
> of the NetLabel subsystem here:
> 
>  * http://free.linux.hp.com/~pmoore/projects/linux_cipso
> 

Maybe this would be easier and better done via existing netfilter infrastructure?
