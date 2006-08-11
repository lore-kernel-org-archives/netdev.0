From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 3/6] ehea: queue management
Date: Fri, 11 Aug 2006 04:32:04 +0400
Message-ID: <20060811003204.GA6935@martell.zuzino.mipt.ru>
References: <44D99F38.8010306@de.ibm.com> <20060811000540.200CE67B6B@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>, netdev@vger.kernel.org,
	Thomas Klein <tklein@de.ibm.com>, linuxppc-dev@ozlabs.org,
	Christoph Raisch <raisch@de.ibm.com>,
	linux-kernel@vger.kernel.org, Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:30852 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932372AbWHKAcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 20:32:09 -0400
Received: by nf-out-0910.google.com with SMTP id a4so711177nfc
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 17:32:07 -0700 (PDT)
To: Michael Neuling <mikey@neuling.org>
Content-Disposition: inline
In-Reply-To: <20060811000540.200CE67B6B@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static inline u32 map_swqe_size(u8 swqe_enc_size)
> > +{
> > +	return 128 << swqe_enc_size;
> > +}		      ^
> > +		      |
> > +static inline u32|map_rwqe_size(u8 rwqe_enc_size)
> > +{		      |
> > +	return 128 << rwqe_enc_size;
		      ^
> > +}		      |
>		      |
> Snap!  These are ide|tical...
		      |
No, they aren't. -----+

> Name the function after what it does, not after the functions you expect
> to call it.

