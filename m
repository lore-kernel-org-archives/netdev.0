From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: sctp_diag should dump sctp socket type
Date: Sat, 28 May 2016 00:02:55 +0800
Message-ID: <CADvbK_d0H7DG6YQTow6zq37H0cD0Aj0_y4_LoAa1OzkqXodMJQ@mail.gmail.com>
References: <53ebf63eb6de080418949f52d0d3556af2a371e1.1464203668.git.lucien.xin@gmail.com>
	<20160525.122421.1141954704190813920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	Phil Sutter <phil@nwl.cc>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33686 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbcE0QC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:02:56 -0400
In-Reply-To: <20160525.122421.1141954704190813920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 3:24 AM, David Miller <davem@davemloft.net> wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Thu, 26 May 2016 03:14:28 +0800
>
>> For sctp_diag, ss support is not officially available, thus there
>> are no official users of this yet, so we can add this field in the
>> middle of sctp_info without breaking user API.
>
> This is not what matters.
>
> What matters is if a released kernel went out with the existing API.
got you, I will move this field to the end of struct sctp_info.
