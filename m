From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH] crush:Make the function crush_ln static
Date: Tue, 16 Jun 2015 19:12:52 +0300
Message-ID: <CAOi1vP8xL=ZdEH5fcGaMOkKbs5Hdjg9BLe6FxdRGVezdiighyQ@mail.gmail.com>
References: <1433803863-9241-1-git-send-email-xerofoify@gmail.com>
	<CAOi1vP_G6eVwRW4coey4-gUEx3Y2k-pnDfJxMk6Va+C0aTLG-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <CAOi1vP_G6eVwRW4coey4-gUEx3Y2k-pnDfJxMk6Va+C0aTLG-w@mail.gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 9, 2015 at 11:00 AM, Ilya Dryomov <idryomov@gmail.com> wrote:
> On Tue, Jun 9, 2015 at 1:51 AM, Nicholas Krause <xerofoify@gmail.com> wrote:
>> This makes the function, crush_ln static now due to having
>> only one caller in its own definition and declaration file
>> of mapper.c
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  net/ceph/crush/mapper.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ceph/crush/mapper.c b/net/ceph/crush/mapper.c
>> index 5b47736..86778d4 100644
>> --- a/net/ceph/crush/mapper.c
>> +++ b/net/ceph/crush/mapper.c
>> @@ -239,7 +239,7 @@ static int bucket_straw_choose(struct crush_bucket_straw *bucket,
>>  }
>>
>>  // compute 2^44*log2(input+1)
>> -uint64_t crush_ln(unsigned xin)
>> +static uint64_t crush_ln(unsigned xin)
>>  {
>>      unsigned x=xin, x1;
>>      int iexpon, index1, index2;
>
> This is tied up with a bunch of style cleanups, I'll apply it after
> they are sorted out.

I folded your patch into a cleanup commit [1] that also fixed
crush_ln() formatting - I hope you don't mind.

[1] https://github.com/ceph/ceph-client/commit/45c7a1f5df419e53c17f2eeb5680d6fb20a07162

Thanks,

                Ilya
