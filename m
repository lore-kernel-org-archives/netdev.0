From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net 2/2] net: make some functions return void
Date: Mon, 16 Jun 2014 18:16:57 +0200
Message-ID: <87tx7kzv5y.fsf@nemi.mork.no>
References: <cover.1402926490.git.panweiping3@gmail.com>
	<cover.1402926490.git.panweiping3@gmail.com>
	<611ae0d4d819f57c4d0c67afa8ed58b16c7d102a.1402926490.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43600 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbaFPQRF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 12:17:05 -0400
In-Reply-To: <611ae0d4d819f57c4d0c67afa8ed58b16c7d102a.1402926490.git.panweiping3@gmail.com>
	(Weiping Pan's message of "Mon, 16 Jun 2014 21:57:23 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Weiping Pan <panweiping3@gmail.com> writes:

> dev_close_many(), __dev_close_many() and __dev_close() do not need to=
 return a
> int, so make them return void, and modify __dev_change_flags() accord=
ingly.

They may not need to return anything, but IMHO it is more logical to
keep the returned type identical to dev_close().


Bj=C3=B8rn
