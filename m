From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][v4][19/24] Add IPoIB
	(IP-over-InfiniBand) driver
Date: Mon, 20 Dec 2004 08:45:49 -0800
Message-ID: <52is6wkjeq.fsf@topspin.com>
References: <200412192215.69tnzAhGIT1vQGLF@topspin.com>
	<200412192215.fZX1ZQqQD4QGkKcF@topspin.com>
	<20041220.155836.75677852.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?b?GyRCNUhGIzFRGyhC?= =?iso-2022-jp?b?GyRCTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20041220.155836.75677852.yoshfuji@linux-ipv6.org> (YOSHIFUJI
	Hideaki's message of "Mon, 20 Dec 2004 15:58:36 +0900 (JST)")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    YOSHIFUJI> above entries does not seem to appropriate for enum
    YOSHIFUJI> (than #define).

As Arnd mentioned, I thought enum values were preferred to using the
preprocessor.  What's the advantage of converting to macros (which
have no type, are invisible to the compiler, etc)?

Thanks,
  Roland
