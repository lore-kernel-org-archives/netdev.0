From: Wedson Almeida Filho <wedsonaf@gmail.com>
Subject: Re: [PATCH v2] [NET]: Unmap fragment page once iterator is done
Date: Mon, 24 Jun 2013 15:47:18 -0700
Message-ID: <CANeycqrPeBvOQeSmRZGcJwCvW=W=Hr+QW8O-99TB_Cqpv5Qr_Q@mail.gmail.com>
References: <1372055628-27044-1-git-send-email-wedsonaf@gmail.com>
	<51C820E7.6040004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C820E7.6040004@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The summary line of the original commit is "[NET]: Zerocopy sequential
reading of skb data".

On Mon, Jun 24, 2013 at 3:35 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 24-06-2013 10:33, Wedson Almeida Filho wrote:
>
>> Callers of skb_seq_read() are currently forced to call
>> skb_abort_seq_read()
>> even when consuming all the data because the last call to skb_seq_read
>> (the
>> one that returns 0 to indicate the end) fails to unmap the last fragment
>> page.
>
>
>> With this patch callers will be allowed to traverse the SKB data by
>> calling
>> skb_prepare_seq_read() once and repeatedly calling skb_seq_read() as
>> originally
>> intended (and documented in the original commit 677e90eda), that is, only
>> call
>
>
>    Please also specify the summary line of that commit.
>
>
>> skb_abort_seq_read() if the sequential read is actually aborted.
>
>
>> Signed-off-by: Wedson Almeida Filho <wedsonaf@gmail.com>
>
>
> WBR, Sergei
>
