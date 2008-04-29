From: "Mile Davidovic" <md4linux@gmail.com>
Subject: Network driver questions
Date: Tue, 29 Apr 2008 15:21:23 +0200
Message-ID: <17896ec80804290621w1b4573c4lc0fa7eaec4f6c7dd@mail.gmail.com>
References: <17896ec80804290540s492962a6ke0ab8790755337de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:63494 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755795AbYD2NVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 09:21:24 -0400
Received: by mu-out-0910.google.com with SMTP id i10so3778092mue.1
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 06:21:23 -0700 (PDT)
In-Reply-To: <17896ec80804290540s492962a6ke0ab8790755337de@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
We have some dedicated interface for connecting various external
devices (NOR, ONENAND, SMSC network adapter), similar to PCI except
one big difference/restriction:

we can not work in atomic context because low lever drivers have such
limitation.

I would like to write network driver (for SMSC chip for example) with
this restriction.

Do we have some network driver which also have suffer from similar restrictions?

Thanks in advance
Mile
