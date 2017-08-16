From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [patch net-next 1/3] idr: Use unsigned long instead of int
Date: Thu, 17 Aug 2017 00:44:10 +0300
Message-ID: <20170816214410.GA13430@avx2>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
 <1502849538-14284-2-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Mi <chrism@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1502849538-14284-2-git-send-email-chrism@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	[CC trimmed]

On Tue, Aug 15, 2017 at 10:12:16PM -0400, Chris Mi wrote:
> IDR uses internally radix tree which uses unsigned long. It doesn't
> makes sense to have index as signed value.

It doesn't. But it makes sense to use "unsigned int" because it
generates smaller code on x86_64.
