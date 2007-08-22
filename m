From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH -mm] drivers/net/e1000e/netdev.c warning
	fix
Date: Wed, 22 Aug 2007 07:40:41 -0700
Message-ID: <46CC4AE9.5070007@intel.com>
References: <46CC316D.2020906@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux NICS <linux.nics@intel.com>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46CC316D.2020906@googlemail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Michal Piotrowski wrote:
> Hi,
> =

> This patch fixes the following compilation warning
> =

> drivers/net/e1000e/netdev.c: In function =E2=80=98e1000_setup_rctl=E2=80=
=99:
> drivers/net/e1000e/netdev.c:1963: warning: unused variable =E2=80=98pages=
=E2=80=99
> =

> Regards,
> Michal
> =


also exposes a symbol issue. I think I want to remove this #ifdef =

CONFIG_E1000_DISABLE_PACKET_SPLIT from this driver alltogether...

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
