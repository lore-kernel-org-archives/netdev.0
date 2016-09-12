From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/26] pch_gbe: constify local structures
Date: Sun, 11 Sep 2016 19:48:19 -0700 (PDT)
Message-ID: <20160911.194819.1394072668837372328.davem@davemloft.net>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
        <1473599168-30561-26-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1473599168-30561-26-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Julia, I went over the networking driver patches in this series and
I have to say that I'd rather see these changes be more durable
and self-checking.

By this I mean that I want you to also make the driver private pointer
that holds these structures be const too.

Then if there are really any assignments to the objects being marked
const, it will show immediately.

Thank you.
