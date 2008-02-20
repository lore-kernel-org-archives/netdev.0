From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH 1/2] bluetooth : put hci dev after del conn
Date: Wed, 20 Feb 2008 08:17:31 +0800
Message-ID: <a8e1da0802191617p7b5630a3mf017c9f0fdb52bc8@mail.gmail.com>
References: <20080218075555.GA5940@darkstar.te-china.tietoenator.com>
	<20080218.204457.167455192.davem@davemloft.net>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sf.net
To: "David Miller" <davem@davemloft.net>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080218.204457.167455192.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Feb 19, 2008 12:44 PM, David Miller <davem@davemloft.net> wrote:
> From: Dave Young <hidave.darkstar@gmail.com>
> Date: Mon, 18 Feb 2008 15:55:55 +0800
>
> > Move hci_dev_put to del_conn to avoid hci dev going away before hci conn.
>
> This looks correct so I have applied it.
>
> > Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
>
> Please remove the extraneous space at the end of your
> signoff line next time :-)

Will do :)

>
> Also, I reworked the loop in del_conn() so that it no longer
> generates a compile warning, so I had to apply your patch
> by hand.
>

Thanks a lot.

Regards
dave

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
