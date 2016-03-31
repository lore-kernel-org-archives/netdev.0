From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: possible bug in latest network tree
Date: Thu, 31 Mar 2016 15:34:40 -0700
Message-ID: <CAM_iQpWHT-iMYm++CroUZO9Czih7xOnbDkauhTP8qhtqHLbpag@mail.gmail.com>
References: <660C7E53FDDFB64C8741117E0D659AAAB8463B9F@ORSMSX116.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Light, John J" <john.j.light@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:32906 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266AbcCaWel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 18:34:41 -0400
Received: by mail-yw0-f181.google.com with SMTP id h65so118081793ywe.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 15:34:41 -0700 (PDT)
In-Reply-To: <660C7E53FDDFB64C8741117E0D659AAAB8463B9F@ORSMSX116.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 2:05 PM, Light, John J <john.j.light@intel.com> wrote:
>
> Maybe the problem is that the default shouldn't be to a TCP value, but should be a 'transport' value.
>

The code is fine because net->ipv4 is always there, it doesn't
depend on any CONFIG, so it is safe for dccp to use too, although
I agree it is a bit ugly.
