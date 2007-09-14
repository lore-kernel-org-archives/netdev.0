From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Fri, 14 Sep 2007 18:32:11 -0400
Message-ID: <46EB0BEB.2090808@garzik.org>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070914211210.GB12444@fieldses.org> <46EAF9CD.1090808@garzik.org> <20070914211828.GC12444@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070914211828.GC12444@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J. Bruce Fields wrote:
> On Fri, Sep 14, 2007 at 05:14:53PM -0400, Jeff Garzik wrote:
>> J. Bruce Fields wrote:
>>> On Fri, Sep 14, 2007 at 03:07:46PM -0400, Jeff Garzik wrote:
>>>> I've been waiting for years for a smart person to come along and write a 
>>>> POSIX-only distributed filesystem.
>>> What exactly do you mean by "POSIX-only"?
>> Don't bother supporting attributes, file modes, and other details not 
>> supported by POSIX.  The prime example being NFSv4, which is larded down 
>> with Windows features.
> 
> I am sympathetic....  Cutting those out may still leave you with
> something pretty complicated, though.

Far less complicated than NFSv4.1 though (which is easy :))


>> NFSv4.1 adds to the fun, by throwing interoperability completely out the 
>> window.
> 
> What parts are you worried about in particular?

I'm not worried; I'm stating facts as they exist today (draft 13):

NFS v4.1 does something completely without precedent in the history of 
NFS:  the specification is defined such that interoperability is 
-impossible- to guarantee.

pNFS permits private and unspecified layout types.  This means it is 
impossible to guarantee that one NFSv4.1 implementation will be able to 
talk another NFSv4.1 implementation.

Even if Linux supports the entire NFSv4.1 RFC (as it stands in draft 13 
anyway), there is no guarantee at all that Linux will be able to store 
and retrieve data, since it's entirely possible that a proprietary 
protocol is required to access your data.

NFSv4.1 is no longer a completely open architecture.

	Jeff




