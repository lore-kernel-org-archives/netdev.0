From: "Banerjee, Debabrata" <dbanerje@akamai.com>
Subject: Re: [PATCH] tcp: Fix RFC reference in comment
Date: Tue, 13 Jan 2015 16:42:50 -0500
Message-ID: <D0DAFA79.4435F%dbanerje@akamai.com>
References: <1421183431-29915-1-git-send-email-dbanerje@akamai.com>
 <CAK6E8=d6NMZjyH1JFoJX_ioAdQNYCAvH-G3ja9fScwW9u2=NFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=d6NMZjyH1JFoJX_ioAdQNYCAvH-G3ja9fScwW9u2=NFQ@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/13/15, 4:36 PM, "Yuchung Cheng" <ycheng@google.com> wrote:

>On Tue, Jan 13, 2015 at 1:10 PM, Debabrata Banerjee <dbanerje@akamai.com>
>wrote:
>>
>> -/* RFC2861. Reset CWND after idle period longer RTO to "restart
>>window".
>> +/* RFC2581 4.1. Reset CWND after idle period longer RTO to "restart
>>window".
>>   * This is the first part of cwnd validation mechanism. */
>>  static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry
>>*dst)
>>  {
>
>RFC2861 resets the cwnd like in RFC2581, but the rest of the code
>implements RFC2861. So I think the current comment is fine.


No RFC2861 is an experimental RFC that's implemented in
tcp_cwnd_application_limited(). RFC2861 Recommends reducing the cwnd by
averaging the current cwnd and the used cwnd as the new cwnd.


RFC2581 4.1 Says to set cwnd to initial cwnd if more than one rto has
passed since the last send. This is what is implemented in the function
above.


-Debabrata
