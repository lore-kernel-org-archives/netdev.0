From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Use defaults when no route options are available
Date: Wed, 04 Nov 2009 05:28:16 -0800 (PST)
Message-ID: <20091104.052816.74593826.davem@davemloft.net>
References: <4AF07024.80103@gmail.com>
	<1257276085-13681-1-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, netdev@vger.kernel.org, ori@comsleep.com,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: gilad@codefidence.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756127AbZKDN1x@vger.kernel.org>
In-Reply-To: <1257276085-13681-1-git-send-email-gilad@codefidence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gilad Ben-Yossef <gilad@codefidence.com>
Date: Tue,  3 Nov 2009 21:21:25 +0200

> Trying to parse the option of a SYN packet that we have
> no route entry for should just use global wide defaults
> for route entry options.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>

The tester has indicated that this doesn't solve things
for them.  I suspect there is another dependency on 'dst'
not being NULL in another path somewhere.

So until this is fully resolved I'm holding off on applying
this patch.
