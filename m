From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 79891] New: Router causes TCP retransmits for windows
 hosts after "ip_forward: fix inverted local_df test"
Date: Fri, 11 Jul 2014 11:38:33 -0700
Message-ID: <CAHA+R7PDJ42Y1Wovtw=dzN-JqQjcamPtDPSmS_SyUK95JNp_aA@mail.gmail.com>
References: <20140710064433.1fd17105@samsung-9>
	<CAHA+R7N0ZgLfZNMrnHyRD+C=rGD86QXVkE0weLOLCM9npXMozg@mail.gmail.com>
	<1405102310.26540.83.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	stable <stable@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1405102310.26540.83.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2014 at 11:11 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Thu, 2014-07-10 at 10:11 -0700, Cong Wang wrote:
>> On Thu, Jul 10, 2014 at 6:44 AM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>> >
>> > After upgrading a router to Linux 3.2.60 most windows machines behind it
>> > started experiencing connection stalls. Downgrade to 3.2.59 resolved the
>> > problem. Using git bisect I pinpointed it to
>> > "59d9f389df3cdf72833d5ee17c3fe959b6bdc792 is the first bad commit", which
>> > entered the kernel from here
>> > http://marc.info/?l=linux-netdev&m=139949081418806&w=2
>> >
>>
>> This commit should have been reverted for older kernels like 3.2.y.
>
> Really?  We already had fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in
> forwarding path") backported in 3.2.57.

I haven't read the code, but according to a previous discussion it sounds
like that should be reverted:

http://lists.openwall.net/netdev/2014/06/11/67
