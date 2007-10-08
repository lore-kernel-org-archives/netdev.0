From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: [ofa-general] RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 8 Oct 2007 15:36:52 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903BC14B6@orsmsx414.amr.corp.intel.com>
References: <1191868010.4335.33.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>
	<1191876530.4373.58.camel@localhost>
	<20071008.142626.26988698.davem@davemloft.net>
	<1191882858.4373.103.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: <hadi@cyberus.ca>,
	"David Miller" <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <1191882858.4373.103.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> If  net_device_subqueue is visible from both driver and core=20
> scheduler area (couldnt tell from looking at whats in there=20
> already), then that'll do it.

Yes, I use the net_device_subqueue structs (the state variable in there)
in the prio and rr qdiscs right now.  It's an indexed list at the very
end of struct netdevice.

-PJ Waskiewicz
