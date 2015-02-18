From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v2] ematch: Fix auto-loading of ematch modules.
Date: Tue, 17 Feb 2015 21:17:04 -0800
Message-ID: <CAHA+R7NuQh250szoSnJHUF6-KzjhtU=vpJctCKis=KWnw=JuGw@mail.gmail.com>
References: <CAHA+R7Os10B8KuBV0K9qp48zo2+=_aXUR-k5ocXjEWYqtq222w@mail.gmail.com>
	<20150217191520.GA15405@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:46947 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbbBRFRE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 00:17:04 -0500
Received: by iecvy18 with SMTP id vy18so46132945iec.13
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 21:17:04 -0800 (PST)
In-Reply-To: <20150217191520.GA15405@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2015 at 11:15 AM, Ignacy Gaw=C4=99dzki
<ignacy.gawedzki@green-communications.fr> wrote:
> In tcf_em_validate(), after calling request_module() to load the
> kind-specific module, set em->ops to NULL before returning -EAGAIN, s=
o
> that module_put() is not called again by tcf_em_tree_destroy().
>
> Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communicat=
ions.fr>


Acked-by: Cong Wang <cwang@twopensource.com>
