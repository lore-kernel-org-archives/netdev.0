From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: incorrect defines in mii.h
Date: Wed, 16 May 2007 11:01:04 +0400
Message-ID: <8496f91a0705160001t1cb1f3aj30642db713bccbe3@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:56506 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbXEPHBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 03:01:05 -0400
Received: by nz-out-0506.google.com with SMTP id r28so457786nza
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 00:01:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all!

The following defines are incorrect (include/linux/mii.h):

#define BMSR_100FULL2           0x0200  /* Can do 100BASE-T2 HDX */
#define BMSR_100HALF2           0x0400  /* Can do 100BASE-T2 FDX */

it must be

#define BMSR_100HALF2           0x0200  /* Can do 100BASE-T2 HDX */
#define BMSR_100FULL2           0x0400  /* Can do 100BASE-T2 FDX */

Best Regards,
Matvejchikov Ilya.
