From: James Carlson <carlsonj@workingcode.com>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Wed, 8 Feb 2006 17:14:13 -0500
Message-ID: <17386.27957.822041.83512@gargle.gargle.HOWL>
References: <20060208222559.GA14543@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ftp.linux.org.uk>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: Alexey Dobriyan's message of 9 February 2006 01:28:47
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan writes:
> -	if (ap == 0)
> +	if (!ap)

And the solution is to treat it as a boolean instead?!  I'm not sure
which is more ugly.

Why wouldn't explicit comparison against NULL be the preferred fix?

-- 
James Carlson         42.703N 71.076W         <carlsonj@workingcode.com>
