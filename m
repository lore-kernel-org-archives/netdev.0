From: Joe Perches <joe@perches.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next V2 2/2] intel: ixgbevf:
 Support Windows hosts (Hyper-V)
Date: Mon, 18 Apr 2016 10:00:19 -0700
Message-ID: <1460998819.1917.10.camel@perches.com>
References: <1460956943-17560-1-git-send-email-kys@microsoft.com>
 <1460956969-17601-1-git-send-email-kys@microsoft.com>
 <1460956969-17601-3-git-send-email-kys@microsoft.com>
 <CAKgT0UdLxSk6CKVAt232fdthMtUbn9FLru9Q9w1Qjjdv_zKA4g@mail.gmail.com>
 <BL2PR03MB19081E9C9AAB13E6F608D08FA06B0@BL2PR03MB1908.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "olaf@aepfle.de" <olaf@aepfle.de>, Netdev <netdev@vger.kernel.org>,
 Jason Wang <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "jackm@mellanox.com" <jackm@mellanox.com>,
 "yevgenyp@mellanox.com" <yevgenyp@mellanox.com>,
 John Ronciak <john.ronciak@intel.com>,
 intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
 "eli@mellanox.com" <eli@mellanox.com>, Robo Bot <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: KY Srinivasan <kys@microsoft.com>, Alexander Duyck
 <alexander.duyck@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BL2PR03MB19081E9C9AAB13E6F608D08FA06B0@BL2PR03MB1908.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-18 at 16:52 +0000, KY Srinivasan wrote:
[]
> > > +bool ixgbevf_on_hyperv(struct ixgbe_hw *hw)
> > > +{
> > > +=A0=A0=A0=A0=A0=A0=A0if (hw->mbx.ops.check_for_msg =3D=3D NULL)
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return true;
> > > +=A0=A0=A0=A0=A0=A0=A0else
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return false;
> > > +}

trivia:

bool func(...)
{
	if (<bar>)
		return true;
	else
		return false;
}

can generally be written as:

bool func(...)
{
	return <bar>;
}
