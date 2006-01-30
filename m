From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATH] acxsm: Move WEP code into softmac
Date: Mon, 30 Jan 2006 09:18:28 +0200
Message-ID: <200601300918.28664.vda@ilport.com.ua>
References: <200601291526.09333.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <200601291526.09333.carlos@cmartin.tk>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Sunday 29 January 2006 16:26, Carlos Mart=EDn wrote:
> Hi,
>=20
>  This patch moves the WEP handling code to use the softmac layer and=20
> implements acx_e_ieee80211_set_security(), based on the rt2x00 project's =
one.

Applied, thanks!
=20
>  I do have a couple of questions though:
>=20
> 1) adev->wep_restricted =3D 0 is the same as an open auth system, and=20
> adev->wep_restricted =3D 1 is the same as having a shared key auth system=
,=20
> right?
>=20
> 2) What is the purpose of the index field in key_struct_t? I've assumed i=
t is=20
> the same as adev->wep_current_index, but I'm not sure this is correct.

To be honest, I did not pay much attention to inner WEP workings...
=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
