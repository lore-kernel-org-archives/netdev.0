From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] anycast support for IPv6, updated to 2.5.44
Date: Wed, 19 Mar 2003 19:23:31 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030319.192331.95884882.davem@redhat.com>
References: <OFC909BFEE.F581E26E-ON88256C60.0072A662@boulder.ibm.com>
	<20030319.163105.44963500.davem@redhat.com>
	<20030320.120136.108400165.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@wide.ad.jp
In-Reply-To: <20030320.120136.108400165.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp>
   Date: Thu, 20 Mar 2003 12:01:36 +0900 (JST)

   In article <20030319.163105.44963500.davem@redhat.com> (at Wed, 19 Mar 2003 16:31:05 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:
   
   > I'm going to apply this, with the small change that dev_getany() is
   > renamed to dev_get_by_flags() which more accurately describes
   > what the routine does.
   
   Again: I don't like API at all.
   
   Anycast address management itself in that patch would be ok.
   However, JOIN/LEAVE is NOT useful and userland application will be 
   incompatible with other implementation. (sigh...)
   I think linux likes unicast model (assign address like unicast address), too.
   
Please propose alternative API, or do you suggest not
to export this facility to user at all?

   And, we see __constant_{hton,ntoh}{l,h}() again...
   
I will fix this, thank you for mentioning this.
