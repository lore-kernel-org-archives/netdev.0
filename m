From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 0/6 NEXT]staging: r8723au: Add new driver
Date: Mon, 31 Mar 2014 02:14:08 +0200
Message-ID: <wrfjzjk7rzqn.fsf@redhat.com>
References: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
 <1396063566.31134.42.camel@joe-AO722> <53363E1E.6050308@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, gregkh@linuxfoundation.org,
 devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <53363E1E.6050308@lwfinger.net> (Larry Finger's message of "Fri,
 28 Mar 2014 22:29:34 -0500")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger@lwfinger.net> writes:
> On 03/28/2014 10:26 PM, Joe Perches wrote:
>> On Fri, 2014-03-28 at 21:37 -0500, Larry Finger wrote:
>>> The Realtek USB device RTL8723AU is found in Lenovo Yoga 13 tablets.
>>> A driver for it has been available in a GitHub repo for several months.
>> []
>>>   133 files changed, 89878 insertions(+)
>>
>> eek.  realtek don't do small or concise.
>
> No, they do not. Those 90 K lines are after Jes and I deleted several
> thousand lines. Of course, all these USB drivers have a complete MAC
> stack - they do not do mac80211. :(
>
> Larry

We're not done with it yet, this is still work in progress. If you want
to compare it to what it was before, try this:

git clone https://github.com/lwfinger/rtl8723au.git

[jes@ultrasam rtl8723au]$ git diff cd93a4ae4151d69e9d198d8d4b3ef95c0e7714b6..kernel_version | diffstat -s
 207 files changed, 58354 insertions(+), 129109 deletions(-)

It'll get even 'smaller' :)

Jes
