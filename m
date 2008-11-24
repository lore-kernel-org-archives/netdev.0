From: Marcel Holtmann <holtmann@linux.intel.com>
Subject: Re: pull request: wireless-2.6 2008-11-18
Date: Mon, 24 Nov 2008 04:50:51 +0100
Message-ID: <7E134DC0-A86D-460A-B5DC-22E6D9BEED92@linux.intel.com>
References: <20081119000719.GA19756@tuxdriver.com> <1ba2fa240811182246m17a6baf0ybde19af030a65819@mail.gmail.com> <1ba2fa240811190134u7974a840i532e8ed0e18f8c72@mail.gmail.com> <20081119143919.GA3485@tuxdriver.com> <1227497655.2548.257.camel@debian.sh.intel.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Tomas Winkler <tomasw@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752823AbYKXDvK@vger.kernel.org>
In-Reply-To: <1227497655.2548.257.camel@debian.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yi,

>> The iwlwifi drivers have been hitting these problems for months,
>> and I have seen no effort by your team to address the problems.
>> It is possible that your team is working on them behind closed doors
>> and will eventually throw something over the wall to us.  I'm tired
>> of waiting for that, and I imagine that hordes of iwlagn users are
>> tired of waiting as well.
>
> This is not correct. We are tracing this problem in our bugzilla.  
> And it
> is the open place. Much more people have used it for a much longer  
> time
> even before the kernel bugzilla existed. If you take a look at the  
> bug,
> you know how much effort we put on it:
> http://www.intellinuxwireless.org/bugzilla/show_bug.cgi?id=1703

and just relying on Bugzilla is not gonna be good enough. The Linux  
kernel development has always been done via mailing lists. And while  
there is a kernel and other Bugzillas, the main authority is still the  
mailing list. So if you wanna get massive feedback or have testing  
patches for debugging, then these need to be posted to linux-wireless  
and not "hidden" into a Bugzilla.

Using Bugzilla for tracking is perfectly fine, but you have to treat  
it as second citizen when it comes to upstream development. Reinette  
is trying to bridge the gap between the Bugzilla by pointing people to  
the patches in the Bugzilla when new reports come to the mailing list.  
And this has to be done more actively. I prefer if we remove any  
Bugzilla discussion for complicated issues to the mailing list.

If we really need it, then someone has to start a iwlwifi-debugging  
kernel tree that derives from wireless-testing where all patches are  
available via GIT and easy to review. Or ask John to create a iwlwifi- 
debugging branch in wireless-testing. I am happy to run such tree. And  
then use WARN() so I can just call kerneloops to push any stack traces.

>> Johannes has presented us with plausible fixes, and people are
>> reporting that the patches work for them.  I can merge these patches,
>> or wait/hope/pray for some to come from your team.  Experience
>> suggests
>> that if fixes do come from your team that they will either be buried
>> in some monster patch that largely addresses something else, or
>> that the patches will arrive with a changelog that is terse and/or
>> unintelligble.  Subsequently, I am not optimistic about waiting.
>>
>> I think Johannes cited four different bugzilla.kernel.org entries
>> between those two patches.  What is your team doing to address
>> those bugs?
>
> Johannes' effort is great and should certainly be praised. But looking
> down upon Intel's effort is nonsense. We suspected this alignment  
> issue
> in the very beginning. But the set of users helped us to debug with  
> this
> problem happened to have a different root cause than Johannes. Thus  
> came
> with the alignment BUG_ON assert put into the code in case other  
> people
> experience with it (unfortunately, it was a wrong one. As I had
> appologized for this already.)
>
> The problem should at least have two causes. Johannes had resolved one
> of them. The other one (AFAICS) relates to be in an 11n AP environment
> (no need to be associated with it) and takes longer time to reproduce.
> We will keep tracking it whatever we you think us about it.

I do have a perfect environment in Vancouver that allows me to trigger  
this behavior within a few minutes. So if you really wanna debug this,  
then just send debug patches to the mailing list and I am happy to run  
such kernels. Only minor details is that you have to wait until the  
end of December before I am back there ;)

Regards

Marcel
