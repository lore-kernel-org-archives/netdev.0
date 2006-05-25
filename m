From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 0/4] NetLabel
Date: Thu, 25 May 2006 17:14:34 -0400
Message-ID: <44761E3A.9050801@hp.com>
References: <44760E29.4070407@hp.com> <20060525135846.44791440@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525135846.44791440@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 25 May 2006 16:06:01 -0400
> Paul Moore <paul.moore@hp.com> wrote:
>>This patch introduces a new kernel feature designed to support labeled
>>networking protocols such as RIPSO and CIPSO.  These protocols are required to
>>interoperate with existing "trusted" operating systems such as Trusted Solaris.
>>I am posting the patch now not because I feel it is ready for inclusion into
>>any of the main kernel trees but because it is usable and I would like to
>>solicit comments from the community sooner rather than later.
> 
> Maybe this would be easier and better done via existing netfilter infrastructure?

I think this would be rather difficult on the outbound side as protocols like CIPSO and RIPSO add IP options to the packet.  I may be wrong but I thought that adding to the size of the packet was a no-no in netfilter?  Also, doesn't netfilter get the packet after the checksum has been calculated and the packet has gone through the xfrm infrastructure?

-- 
paul moore
linux security @ hp
