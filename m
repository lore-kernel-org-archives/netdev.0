From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Remaining problems in firewire-net
Date: Tue, 16 Nov 2010 16:11:54 +0100
Message-ID: <20101116161154.655470f5@stein>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
	<1289795401.11881.62.camel@maxim-laptop>
	<20101115090103.0df0b5ef@stein>
	<1289878275.16486.57.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1289878275.16486.57.camel@maxim-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Nov 16 Maxim Levitsky wrote:
> The IP over 1394 tells that unicast can also use ISO transactions.
> However, it doesn't say how to negotiate the ISO channel number, thus a
> logical conclusion is that its not possible to use ISO transactions for
> unicast.
> Is that right?

To my understanding, any unicast transport method other than block write
to the unicast FIFO are outside the scope of RFC 2734.  At the end of
section 7:
"""
   Unicast IP datagrams whose quality of service is best-effort SHALL be
   contained within the data payload of 1394 block write transactions [...]
"""
"""
   Unicast IP datagrams that require quality of service other than
   best-effort are beyond the scope of this standard.
"""
-- 
Stefan Richter
-=====-==-=- =-== =----
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Beautiful is writing same markup. Internet Explorer 9 supports
standards for HTML5, CSS3, SVG 1.1,  ECMAScript5, and DOM L2 & L3.
Spend less time writing and  rewriting code and more time creating great
experiences on the web. Be a part of the beta today
http://p.sf.net/sfu/msIE9-sfdev2dev
