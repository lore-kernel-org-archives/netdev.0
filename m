From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC 01/10] devres: add devm_alloc_percpu()
Date: Wed, 01 Apr 2015 09:32:01 -0700
Message-ID: <1427905921.31790.23.camel@perches.com>
References: <1427905179-27755-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427905179-27755-1-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> Introduce managed counterparts for alloc_percpu() and free_percpu().
> Add devm_alloc_percpu() and devm_free_percpu() into the managed
> interfaces list.

It'd be nice to add include <linux/percpu.h> to these
files rather than get included indirectly via module.h

>  drivers/base/devres.c                 | 63 +++++++++++++++++++++++++++++++++++
>  include/linux/device.h                | 19 +++++++++++
