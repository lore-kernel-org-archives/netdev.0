From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.17 regression: Very slow net transfer from some hosts
Date: Tue, 11 Apr 2006 16:54:35 -0400
Message-ID: <443C178B.3030805@psc.edu>
References: <443C03E6.7080202@gentoo.org> <443C024C.2070107@psc.edu> <443C0B74.50305@gentoo.org> <443C09A7.2040900@psc.edu> <443C1738.20605@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750941AbWDKUyp@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <443C1738.20605@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is almost certainly due to a buggy firewall that doesn't understand 
TCP window scaling.  I've usually seen this in the past with OpenBSD 
firewalls.  Do you have one of these in your path?

Thanks,
   -John
