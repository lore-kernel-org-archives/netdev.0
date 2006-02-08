From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Wed, 08 Feb 2006 14:23:56 -0800
Message-ID: <ada8xslbibn.fsf@cisco.com>
References: <20060208222559.GA14543@mipter.zuzino.mipt.ru>
	<17386.27957.822041.83512@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: James Carlson <carlsonj@workingcode.com>
In-Reply-To: <17386.27957.822041.83512@gargle.gargle.HOWL> (James Carlson's
 message of "Wed, 8 Feb 2006 17:14:13 -0500")
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    James> And the solution is to treat it as a boolean instead?!  I'm
    James> not sure which is more ugly.

    James> Why wouldn't explicit comparison against NULL be the
    James> preferred fix?

"if (ptr)" and "if (!ptr)" are the preferred idiom for testing whether
a pointer is NULL.  What is gained by writing "if (ptr != NULL)" ?
