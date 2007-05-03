From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: finding your own dead "CONFIG_" variables
Date: Thu, 3 May 2007 02:37:20 -0700
Message-ID: <a781481a0705030237l7d636b55t93f2ee5151cd7709@mail.gmail.com>
References: <Pine.LNX.4.64.0705030400120.20539@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:35956 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030991AbXECJhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 05:37:21 -0400
Received: by wr-out-0506.google.com with SMTP id 76so456636wra
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 02:37:21 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0705030400120.20539@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> http://fsdev.net/wiki/index.php?title=Dead_CONFIG_variables

> kcfiles=$(find . -name "Kconfig*")

Suggest: configfiles=$(find . -name 'Kconfig*' -or -name '*defconfig*')

Some CONFIG_ options exist that are not declared anywhere in the
Kconfig files but defined directly in the arch/.../*defconfig* files.
