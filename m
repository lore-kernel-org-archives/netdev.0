From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] acx: Transform semaphore to mutex
Date: Mon, 6 Feb 2006 09:04:12 +0200
Message-ID: <200602060904.12571.vda@ilport.com.ua>
References: <200602051656.57214.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <200602051656.57214.carlos@cmartin.tk>
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

On Sunday 05 February 2006 17:56, Carlos Mart=EDn wrote:
> Hi,
>=20
>  The attached patch transform the semaphore to a mutex. That's how we use=
 it,=20
> it's faster and makes the binary smaller. It also deletes the semaphore d=
ebug=20
> functions because I the kernel takes care of that now. Just yell if I've=
=20
> misunderstood.
>=20
>    text    data     bss     dec     hex filename
>  113475    1520      20  115015   1c147 acx.ko-sem
>  111033    1520      20  112573   1b7bd acx.ko
>=20
> This only works for newer kernels, so I suppose it could be kept as an=20
> into-mainline patch. People with newer kernels probably want this patch.

http://195.66.192.167/linux/acx_patches/acx-sem-to-mutex.patch

Thanks!
=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
