From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Fri, 15 May 2015 16:26:41 -0400
Message-ID: <2152640.VCSTRrx26A@sifl>
References: <cover.1429252659.git.rgb@redhat.com> <2918460.dpKocsKt4o@x2> <20150515004855.GB10526@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Steve Grubb <sgrubb@redhat.com>,
	containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	eparis@parisplace.org, arozansk@redhat.com, ebiederm@xmission.com,
	serge@hallyn.com, zohar@linux.vnet.ibm.com,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150515004855.GB10526@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 14, 2015 08:48:55 PM Richard Guy Briggs wrote:
> On 15/05/14, Steve Grubb wrote:
> > What they would want to know is what resources were assigned; if two
> > containers shared a resource, what resource and container was it shared
> > with; if two containers can communicate, we need to see or control
> > information flow when necessary; and we need to see termination and
> > release of resources.
>
> So, namespaces are a big part of this.  I understand how they are
> spawned and potentially shared.  I have a more vague idea about how
> cgroups contribute to this concept of a container.  So far, I have very
> little idea how seccomp contributes, but I assume that it will also need
> to be part of this tracking.

It doesn't, really.  We shouldn't worry about seccomp from a 
namespace/container auditing perspective.  The normal seccomp auditing should 
be sufficient for namespaces/containers.

-- 
paul moore
security @ redhat
