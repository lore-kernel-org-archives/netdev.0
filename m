From: David Ahern <dsahern@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Tue, 31 Oct 2017 16:42:55 -0600
Message-ID: <753dd8a8-5f93-d0cc-bfc7-5696dc7e2296@gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com>
 <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
 <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com>
 <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
 <aa76d6b7-dbb1-5275-09f6-a4450aeceeb2@gmail.com>
 <CAL6e_pfAtUAFRmm_2Ykn43jk-0mQn7f9FAt+CgHV4nFHT-PdPQ@mail.gmail.com>
 <609f2e30-3e9d-f317-e2b4-ba3fb7d20532@gmail.com>
 <CAL6e_pcL3DF1J1-+w0pw0CZ=Zm_BRfKtz=5jML_GcZBZFW1JVA@mail.gmail.com>
 <abb3291a-222a-7eff-724c-9d06fea9f02d@gmail.com>
 <CAL6e_pfr5HRHHU9SiNKZ9dASxVLUBSHeShb_=nNd1Hbna5cR8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Barnhill <0xeffeff@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:50296 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932724AbdJaWm6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:42:58 -0400
Received: by mail-pg0-f52.google.com with SMTP id y5so452651pgq.7
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 15:42:57 -0700 (PDT)
In-Reply-To: <CAL6e_pfr5HRHHU9SiNKZ9dASxVLUBSHeShb_=nNd1Hbna5cR8w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/17 4:20 PM, Jeff Barnhill wrote:
> I was surprised that nlmsg_parse in fib_nl_newrule() didn't pick this
> up, but I verified that the received value for this attribute was 0,
> not 1 (w/o the patch).

It only checks minimum length, not exact length.
