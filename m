From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: Fix resource leak in case of error
Date: Mon, 3 Oct 2016 16:04:42 +0200
Message-ID: <20161003140442.GA13116@localhost.localdomain>
References: <1475391856-15046-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475391856-15046-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 02, 2016 at 09:04:16AM +0200, Christophe JAILLET wrote:
> A call to 'ida_simple_remove()' is missing in the error handling path.
> 
> This as been spotted with the following coccinelle script which tries to
> detect missing 'ida_simple_remove()' call in error handling paths.

Acked-by: Richard Cochran <richardcochran@gmail.com>
