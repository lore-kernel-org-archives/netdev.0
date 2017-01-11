From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 0/2] remove dwc_eth_qos and rename stmicro/stmmac
Date: Wed, 11 Jan 2017 15:06:55 +0000
Message-ID: <329b0d8c-4cda-7238-c229-d69ac251f26b@synopsys.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <0dcdcb5f-200b-b130-9a67-774639353114@st.com>
 <20170111.095256.1057845755758556047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <Joao.Pinto@synopsys.com>, <lars.persson@axis.com>,
        <niklass@axis.com>, <peppe.cavallaro@st.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:38798 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756516AbdAKPHn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:07:43 -0500
In-Reply-To: <20170111.095256.1057845755758556047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Às 2:52 PM de 1/11/2017, David Miller escreveu:
> From: Alexandre Torgue <alexandre.torgue@st.com>
> Date: Wed, 11 Jan 2017 12:39:09 +0100
> 
>> Let's see what David think about that but if there no risk of backward
>> compatibility with DT, I agree with the series.
> 
> I really am generally against driver renames.  The only potentially
> make new users happy, but can only negatively impact existing users.
> 
> The new name is not terribly appropriate either, it is using the name
> of the manufacturer rather than referring to a chipset or a class or
> chipsets.

stmmac is in fact a bundle of Synopsys Ethernet IPs. We can go with Jie'
suggestion a include all the Ips it supports like "Synopsys 10M/100M/1G/eQOS
Ethernet Drivers".

> 
> I don't see what the big deal is in leaving the name as 'stmmac' and
> in a way leaving it alone shows respect for the people who have worked
> on and cared for the stmmac driver for all of these years.

I have a huge respect for STMicroelectronics and above all respect for the
developers that work hard to put things working properly and care for it, and
that's why before starting developing I had a discussion with stmmac maintainers
in order to align with them. From me you can only expect collaboration, help and
dedication, since Linux is for common good right, or at least I believe so.
Another thing to point is that I wish that Alexandre and Peppe remain
maintainers since they are doing an excelent job.

The goal of this work is to improve code organization and future merge of other
Synopsys Ethernet IP driver that will be able to merge into this "synopsys
driver bundle". That is why I volunteered to merge the dwc qos axis' driver into
stmmac.

Thanks.
Joao


> 
> Thanks.
> 
