From: Chao Bi <chao.bi@intel.com>
Subject: Re: [PATCH] WIFI: handle a neglected case in
 nl80211_new_interface()
Date: Thu, 28 Nov 2013 11:53:38 +0800
Message-ID: <1385610818.7437.1.camel@bichao>
References: <1385521254.23222.8.camel@bichao>
	 <CAE2MWk=WEwxbnBDhBRHKVQ7JhAwKANv-HQXyK=qTb4qaH4GZRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Ujjal Roy <royujjal@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAE2MWk=WEwxbnBDhBRHKVQ7JhAwKANv-HQXyK=qTb4qaH4GZRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-11-27 at 20:43 +0530, Ujjal Roy wrote:
> Hi,
> 
> 
> We can use IS_ERR_OR_NULL(wdev) to check NULL as well as error value.
> 
> Thanks,
> UjjaL
> 
> On Wed, Nov 27, 2013 at 8:30 AM, Chao Bi <chao.bi@intel.com> wrote:
>         In nl80211_new_interface(), it calls rdev_add_virtual_intf() to create
>         a new interface, however, it only checks whether returned value is err
>         code, but doesn't check if returned value is NULL. The returned 

Thanks Ujjal. I'll update it.
