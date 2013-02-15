From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Thu, 14 Feb 2013 21:24:11 -0800
Message-ID: <20130214212411.55788ec1.akpm@linux-foundation.org>
References: <1360311077-14474-1-git-send-email-sustrik@250bpm.com>
	<20130214145430.04f8750c.akpm@linux-foundation.org>
	<511DAEA3.4080201@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Eric Wong <normalperson@yhbt.net>
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <511DAEA3.4080201@250bpm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Feb 2013 04:42:27 +0100 Martin Sustrik <sustrik@250bpm.com> wrote:

> > This is a non-back-compatible userspace interface change.  A procfs
> > file which previously displayed
> >
> > 	eventfd-count: nnnn
> >
> > can now also display
> >
> > 	eventfd-mask: nnnn
> >
> > So existing userspace could misbehave.
> >
> > Please fully describe the proposed interface change in the changelog.
> > That description should include the full pathname of the procfs file
> > and example before-and-after output and a discussion of whether and why
> > the risk to existing userspace is acceptable.
> 
> I am not sure what the policy is here. Is not printing out the state of 
> the object acceptable way to maintain backward compatibility? If not so, 
> does new type of object require new procfs file, which, AFAIU, is the 
> only way to retain full backward compatibility?

Adding a new file is the only way I can think of to preserve the API. 
But from Andy's comment is sounds like we don't have to worry a lot
about back-compatibility.
