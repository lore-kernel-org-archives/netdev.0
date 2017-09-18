From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Mon, 18 Sep 2017 10:02:32 +0200
Message-ID: <20170918080232.q2jykg3thzyikv3w@torres.zugschlus.de>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
 <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
 <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
 <370b38d5-346c-91df-4ad4-79886ae3a9ba@redhat.com>
 <a4807126-1f17-20bd-dace-d9c6b6c4787b@redhat.com>
 <E068C58A-DC80-4D98-ADE6-8F05304EC7ED@fb.com>
 <813386f2-81ba-db8c-e86d-f36cd1b89537@redhat.com>
 <BD049B00-DD0A-449F-A017-9E73178685DE@fb.com>
 <10124256-647f-99a5-aa29-8073438a21df@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Josef Bacik <jbacik@fb.com>, Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cole Robinson <crobinso@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <10124256-647f-99a5-aa29-8073438a21df@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 17, 2017 at 09:17:13AM -0400, Cole Robinson wrote:
> On 09/15/2017 01:51 PM, Josef Bacik wrote:
> > Finally got access to a box to run this down myself.  This patch on top of the other patches fixes the problem for me, could you verify it works for you?  Thanks,
> > 
> 
> Yup I can confirm that patch fixes things when applied on top of the
> previous 3 patches. Thanks! Please tag those patches for stable releases
> if appropriate, this is affecting a decent amount of libvirt users

I can also confirm that these four patches fix things for me (on
Debian) as well. Thanks!

I would love to have this in one of Greg's next 4.13 releases.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
