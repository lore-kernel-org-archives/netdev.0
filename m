From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] anycast support for IPv6, updated to 2.5.44
Date: Wed, 19 Mar 2003 19:47:35 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030319.194735.31799019.davem@redhat.com>
References: <20030320.120136.108400165.yoshfuji@wide.ad.jp>
	<20030319.192331.95884882.davem@redhat.com>
	<20030320.124428.95965257.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@wide.ad.jp
In-Reply-To: <20030320.124428.95965257.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp>
   Date: Thu, 20 Mar 2003 12:44:28 +0900 (JST)

   In article <20030319.192331.95884882.davem@redhat.com> (at Wed, 19 Mar 2003 19:23:31 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:
   
   > Please propose alternative API, or do you suggest not
   > to export this facility to user at all?
   
   I like to assign address like unicast (using ioctl and rtnetlink 
   (RTN_ANYCAST)).
   We suggest you not exporting this facilicy until finishing new API
   (And, another API would be standardized;
   This is another reason why I am against exporting that API for now.)

I think anycast addresses are more like multicast than unicast.  Do
you agree about this?

But here is what really matters, does the advanced IPV6 socket API
say anything about a user API for anycast?
