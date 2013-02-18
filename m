From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Mon, 18 Feb 2013 12:57:04 +0100
Message-ID: <51221710.5060102@250bpm.com>
References: <1360311077-14474-1-git-send-email-sustrik@250bpm.com> <20130214145430.04f8750c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Eric Wong <normalperson@yhbt.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130214145430.04f8750c.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/02/13 23:54, Andrew Morton wrote:

> This patch adds userspace interfaces which will require manpage
> updates.  Please Cc Michael and work with him on getting those changes
> completed.

Right. It adds the efd_mask structure. As far as I understand how it 
works is that the actual user-space definition of the structure should 
be provided by glibc (sys/eventfd.h), right?

If so, should the man page be updated now? If so, it may result in the 
situation where the man page describes a structure that's not available 
in the user space yet.

Is there a formal process to do this kind of kernel+glibc+docs changes?

Martin
