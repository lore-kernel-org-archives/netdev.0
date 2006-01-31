From: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
Subject: Re: 2.6.16-rc1-mm4: ACX=y, ACX_USB=n compile error
Date: Tue, 31 Jan 2006 19:59:39 +0100
Message-ID: <200601311959.39285.carlos@cmartin.tk>
References: <20060130133833.7b7a3f8e@zwerg> <200601311658.09423.vda@ilport.com.ua> <20060131193443.5822661b@zwerg>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denis Vlasenko <vda@ilport.com.ua>, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Adrian Bunk <bunk@stusta.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751349AbWAaS7e@vger.kernel.org>
To: "Gabriel C." <da.crew@gmx.net>
In-Reply-To: <20060131193443.5822661b@zwerg>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 31 January 2006 19:34, Gabriel C. wrote:
>=20
> I'm not a kernel hacker :-) and mabye I'm wrong but why not auto sele=
ct
> ACX_{PCI,USB} ?

They can still be both unselected, and that's where the problem lies.

Would it work if you added '&& (ACX_USB || ACX_PCI)' to the end of the=20
'depends' line, or would that just make it unselectable?=20

   cmn
--=20
Carlos Mart=EDn       http://www.cmartin.tk

"Erdbeben? Sicherlich etwas, das mit Erdberen zu tun hat." -- me, parap=
hrased
