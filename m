From: Shirley Ma <xma@us.ibm.com>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Mon, 6 Mar 2006 19:13:34 -0800
Message-ID: <OF336D72E6.999D2A30-ON8725712A.00117C92-8825712A.00116629@us.ibm.com>
References: <20060306145041.320d4dd3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2098467077=="
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	openib-general@openib.org, openib-general-bounces@openib.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <20060306145041.320d4dd3@localhost.localdomain>
To: Stephen Hemminger <shemminger@osdl.org>
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

This is a multipart message in MIME format.
--===============2098467077==
Content-Type: multipart/alternative;
	boundary="=_alternative 001166228825712A_="

This is a multipart message in MIME format.
--=_alternative 001166228825712A_=
Content-Type: text/plain; charset="US-ASCII"

> More likely you are getting hit by the fact that TSO prevents the 
congestion
window from increasing properly. This was fixed in 2.6.15 (around mid of 
Nov 2005).

Yep, I noticed the same problem. After updating to the new kernel, the 
performance are much better, but it's still lower than before.

Thank
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone(Fax): (503) 578-7638
--=_alternative 001166228825712A_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2><tt>&gt; More likely you are getting hit by the fact that
TSO prevents the congestion<br>
window from increasing properly. This was fixed in 2.6.15 (around mid of
Nov 2005).</tt></font>
<br>
<br><font size=2 face="sans-serif">Yep, I noticed the same problem. After
updating to the new kernel, the performance are much better, but it's still
lower than before.<br>
</font>
<br><font size=2 face="sans-serif">Thank<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone(Fax): (503) 578-7638</font>
--=_alternative 001166228825712A_=--

--===============2098467077==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2098467077==--
