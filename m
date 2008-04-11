From: Toshiharu Harada <haradats@nttdata.co.jp>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Fri, 11 Apr 2008 12:57:04 +0900
Message-ID: <47FEE190.7000504@nttdata.co.jp>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp> <20080409132238.GB8489@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080409132238.GB8489@sergelap.austin.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/9/2008 10:22 PM, Serge E. Hallyn wrote:
> First let me point out that reviewing patches is always a lot of work.
> What you've done here by posting an entirely new 30-patch implementation
> of tomoyo when (I hope) you're not even serious about that is to
> basically tell us our time means nothing to you...
> 
> If you *are* serious about it, than to whatever extent I can, which
> isn't very much, I say nack.
You are right. I appreciate your comments and thank you.

> Like you say there appear to be no real remaining objections to the LSM,
> only to the VFS part.  You're going to try to get around the VFS
> objections by not being an LSM?
What annoyed us was the fact we didn't know how the merge would take place.
No nacks can mean no interests and does not mean the ack.
Coding issues/problems can be corrected, but we didn't know how to react with
different way of thinking and concepts. We were at a loss rather than
being frustrated.

BUT I know every those things can't be an excuse. I feel sorry for our
last posting. I apology you all and promise we will never do that.
(I don't mean we will stop submitting)

> Look right now TOMOYO is an out of tree patch.  You want to get it in
> tree.  Don't be too hung up on getting it all in at once.  Why not
> push a subset of the patch without the vfs controls, which will help
> to motivate the vfs controls you need?  You can (1) keep a much smaller
> out of tree patch with your implementation of the vfs controls for your
> current customrs/installations, and/or (2) implement a temporary
> non-pathname-based alternative, say using xattrs to tag files at setup
> time - probably insufficient, but sufficient for people to play.
Yes.

> The smaller patch would also be easier to review.
Yes.

>> Let me explain the reason and the history.
> 
> We remember the history.  On the one hand we feel for you, but on the
> other hand many of us have gone through the same thing, and if you'll
> notice Casey went through the same thing and persisted.
Yes, it was ... really surprising. (I was even scared)

>> We started developing TOMOYO Linux as original patch sets against
>> 2.4 vanilla kernel. We understand the role of LSM, so we ported
>> TOMOYO Linux to use LSM and submitted it to the LKML on 13 June 2007.
>> We kept working to reflect feedbacks from the community and believe
>> no critical Nack remains.
> 
> Right, at this point it's mainly a question of finding a way to upstream
> tomoyo.  (That's mainly *your* burden, but we do try to help :)
It's a great pleasure to receive comments from people.

> Yes, but he didn't say you could implement it in a way that offends the
> affected maintainers.  Nor did he say it's those maintainers'
> responsibility to find you an acceptable solution.  They are in fact
> being very nice by offering you suggestions.
I couldn't agree with you more. I'll never quote that. :)

> Also, isn't Miklos helping you to try and find an acceptable approach?
We started following the thread and found it's very close to
our case. We will watch and join the discussion.

>> Current LSM implementation is sufficient for SELinux
>> and other label based MACs but not for pathname-based MACs.
>> This has been argued in the AppAmor thread for quite a long time.
>> Though proposals had been posted by AppArmor and TOMOYO Linux project,
>> none has been merged until now.
> 
> You're trying to make it sound like you've spent night and day for years
> trying to work with the relevant people to come up with something
> reasonable.  Yet for instance in the thread 
> 	"vfs: add helpers to check r/o bind mounts"
> (april 2) where iiuc two reasonable approaches are discussed, you don't
> even take part.
Right and I am ashamed of it now.

>> We apologize for the confusion we caused in the last posting,
>> but we don't want to give up returning our work to the mainline. 
> 
> I'm glad to hear that.  Please keep trying.
Thank you. (T_T) (crying)

>> We cordially request LSM changes to pass vfsmount parameters.
I wish I could revoke the above statement...

> Again let me point out there is a difference between saying "Linus said
> we can have pathname-based access control, but you won't implement it
> for me" and doing the hard work to come up with something reasonable.
> I know you've tried a few times, but from what I've seen your impression
> of the work you've put into it is far different from my impression of
> it.
Roger. (_ _) (bowing)

Best regards,
Toshiharu

