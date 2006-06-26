From: "Ian Brown" <ianbrn@gmail.com>
Subject: netfilter and packets which are created locally
Date: Mon, 26 Jun 2006 17:39:47 +0300
Message-ID: <d0383f90606260739t20c69a9fneb0a0693f67a898d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.203]:26711 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1030266AbWFZOjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 10:39:48 -0400
Received: by nz-out-0102.google.com with SMTP id o37so819261nzf
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2006 07:39:47 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
  I had looked at the diagrams and read the explanations
about netfilter in Netfilter Architecture page:
http://netfilter.org/documentation/HOWTO/netfilter-hacking-HOWTO-3.html

I want to make sure wheter I undestood something regarding
packets which are created locally (as opposed
to packets that are received on the network interface).

My question is: Do I understand the follwing 2 sceanrios right?
For local packets which are sent out of the machine
it seems to me to be the case. (Am I right?):
Such packets , that are created locally on
the machine, first reach the NF_IP_LOCAL_OUT [5] hook.
Than they go to the routing stage, and than they go to
NF_IP_POST_ROUTING [4]. And then they go out ?
Such packets, which are created locally,  don't pass at all
at the [1] stage, NF_IP_PRE_ROUTING [1] , and not
in NF_IP_LOCAL_IN [2] stage and not in NF_IP_FORWARD [3] .

Is it true?


Suppose I create locally packets which are destined to
myself (like ping myself). I assume that they will go first to the
NF_IP_LOCAL_OUT [5] , than to the routing stage, but will they go
to the NF_IP_POST_ROUTING [4].?

And again,such packets, which are created locally,  don't pass at all
at the [1] stage, NF_IP_PRE_ROUTING [1] , and not
in NF_IP_LOCAL_IN [2] stage and not in NF_IP_FORWARD [3] .

Is it true?

IB
