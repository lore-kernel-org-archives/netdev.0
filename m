From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH 1/1] eventfd: implementation of EFD_MASK flag
Date: Fri, 08 Feb 2013 13:43:04 +0100
Message-ID: <5114F2D8.5020300@250bpm.com>
References: <1360219292-19754-1-git-send-email-sustrik@250bpm.com> <20130207144433.527ef024.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130207144433.527ef024.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02/13 23:44, Andrew Morton wrote:

> That's a nice changelog but it omitted a critical thing: why do you
> think the kernel needs this feature?  What's the value and use case for
> being able to poll these descriptors?

To address the question, I've written down detailed description of the 
challenges of the network protocol development in user space and how the 
proposed feature addresses the problems.

It's too long to fit into ChangeLog, but it may be worth reading when 
trying to judge the merit of the patch.

It can be found here: http://www.250bpm.com/blog:16

Martin
